// <copyright file="EditorialRecoveryCheckTests.cs" company="David Strickland">
// Copyright (c) David Strickland. All rights reserved.
// </copyright>

namespace StoryForge.Endless.Generation.Tests;

using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Serialization;
using StoryForge.Endless.Application.StoryArcs;
using StoryForge.Endless.Generation.Prose;

/// <summary>Checks the staged author-approved episode recovery against engine invariants.</summary>
public sealed class EditorialRecoveryCheckTests
{
    /// <summary>Validates structure, changed completion receipts, and the immutable canon hashes.</summary>
    [Fact]
    public void RebuiltEpisode_PreservesCanonAndValidArcState()
    {
        const string root = @"C:\repos\SRD\StoryForge.Publish\AsTheWorldRolls";
        const string recovery = root + @"\.storyforge\editorial-recovery\20261012-115913";
        var options = new JsonSerializerOptions { Converters = { new JsonStringEnumConverter() } };
        var state = JsonSerializer.Deserialize<StoryArcState>(File.ReadAllText(recovery + @"\rebuilt\context\generation\STORY-ARCS.json"), options)!;
        StoryArcStateValidator.Validate(state);
        for (var chapter = 15; chapter <= 18; chapter++)
        {
            var prose = File.ReadAllText(Path.Combine(recovery, "rebuilt", $"chapter-{chapter:000}.md"));
            Assert.Null(OneWordNarrativeSentenceDetector.FindFirst(prose));
        }

        foreach (var target in state.Arcs.SelectMany(arc => arc.ChapterTargets).Where(target => target.IsCompleted && target.ChapterNumber > 14))
        {
            var prose = File.ReadAllText(Path.Combine(recovery, "rebuilt", $"chapter-{target.ChapterNumber:000}.md"));
            foreach (var quote in target.CompletionEvidence)
            {
                Assert.Contains(quote, prose, StringComparison.Ordinal);
            }
        }

        using var hashes = JsonDocument.Parse(File.ReadAllText(recovery + @"\immutable-canon-hashes.json"));
        Assert.Equal(14, hashes.RootElement.GetArrayLength());
        foreach (var entry in hashes.RootElement.EnumerateArray())
        {
            var hash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(entry.GetProperty("Path").GetString()!)));
            Assert.Equal(entry.GetProperty("Hash").GetString(), hash);
        }
    }
}
