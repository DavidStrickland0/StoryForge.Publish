using System.Text.Json;
using System.Text.Json.Serialization;
using StoryForge.Endless.Application.ChapterPlanning;
using StoryForge.Endless.Application.TextGeneration;
using StoryForge.Endless.Generation.Promotion;
using StoryForge.Endless.Ollama.TextGeneration;
var root = args[0];
var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true, WriteIndented = true, Converters = { new JsonStringEnumConverter() } };
var plan = JsonSerializer.Deserialize<ChapterPlan>(await File.ReadAllTextAsync(Path.Combine(root, "scope-reviewed-plan.json")), options)!;
ChapterPlanValidator.Validate(plan, 5);
var prose = await File.ReadAllTextAsync(Path.Combine(root, "source.md"));
var context = await File.ReadAllTextAsync(Path.Combine(root, "context.txt"));
using var client = new HttpClient { BaseAddress = new Uri(Environment.GetEnvironmentVariable("STORYFORGE_OLLAMA_URL") ?? "http://localhost:11434"), Timeout = TimeSpan.FromHours(1) };
Console.WriteLine("Checking scope-reviewed beat definitions against the same frozen prose with qwen3.5:9b...");
var receipt = await new NarrativePromotionService(new RecordingGenerator(new OllamaTextGenerationService(client, "qwen3.5:9b"), root)).AssessAsync(plan, prose, context, "qwen3.5:9b");
var path = Path.Combine(root, "verified-narrative-promotion.json");
await File.WriteAllTextAsync(path, JsonSerializer.Serialize(receipt, options));
foreach (var outcome in receipt.Outcomes) Console.WriteLine($"{outcome.Id}: supported={outcome.Supported}, promoted={outcome.Promoted}: {outcome.Reason}");
Console.WriteLine($"Report: {path}");
return receipt.Completed ? 0 : 2;

sealed class RecordingGenerator(ITextGenerationService inner, string output) : ITextGenerationService
{
    private int attempt;
    public async Task<TextGenerationResult> GenerateAsync(TextGenerationRequest request, CancellationToken cancellationToken = default)
    {
        var sequence = ++this.attempt;
        Console.WriteLine($"Independent validation attempt {sequence}...");
        await File.WriteAllTextAsync(Path.Combine(output, $"validator-request-{sequence:000}.json"), JsonSerializer.Serialize(request), cancellationToken);
        var result = await inner.GenerateAsync(request, cancellationToken);
        await File.WriteAllTextAsync(Path.Combine(output, $"validator-response-{sequence:000}.json"), result.Text, cancellationToken);
        Console.WriteLine($"Independent validation attempt {sequence} returned; evidence metadata is being checked.");
        return result;
    }
}
