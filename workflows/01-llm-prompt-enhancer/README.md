<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 01 — LLM Prompt Enhancer
![](images/preview.png)

## Overview

This workflow shows you how to build an AI Agent that strengthens and refines text prompts automatically. You will learn the core structure of an agent and how customized agents solve common prompt-creation challenges.

## The Three Core Components of a Customized Agent

- **The Brain:** The model powering the agent (LLMs or VLMs such as Gemma 3, Qwen, LLaMA).
- **The Purpose (Persona):** The agent's identity — its rules, tone, and decision-making style.
- **The Task:** The user's immediate instructions, examples, constraints, or goals.

## The Problem It Solves

- **Unclear or weak prompts** lead to vague or unintended outputs.
- **Slow manual refinement** breaks creative flow.
- **Model-specific prompt formats** — different models require different structures. The agent translates your natural language into the optimized format automatically.

## Key Features

- **Chained Workflow:** Combines a VLM with a generation model.
- **VLM-Driven Prompt Enhancement:** Uses Gemma 3 to refine prompts using text and optional reference images.
- **Fast Iteration:** Reduces the need for manual tweaking.
- **Optimized for Any Modality:** Works for text-to-image, video, 3D, and audio generation.

## How It Works

```
User Instructions -> Prompt Enhancement Agent -> Text Encoding -> Image
```

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 2 packages |
| **Models** | 4 files + Ollama |

## Required Models

| Model | Type | Size |
|-------|------|------|
| `gemma3:latest` | VLM (via Ollama) | ~5 GB |
| `qwen_2.5_vl_7b.safetensors` | Text Encoder | 15.45 GB |
| `qwen_image_vae.safetensors` | VAE | 242 MB |
| `qwen_image_2512_bf16.safetensors` | Image Model | 38.05 GB |
| `Qwen-Image-2512-Lightning-4steps-V1.0-fp32.safetensors` | LoRA | 1.58 GB |

## Required Custom Nodes

- [ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use)
- [comfyui-ollama](https://github.com/stavsap/comfyui-ollama)

## Ollama Setup

This workflow requires [Ollama](https://ollama.com) for the Gemma 3 LLM:

```bash
ollama pull gemma3:latest
```

## How to Use

1. Load `workflow.json` into ComfyUI
2. Configure your prompt and click **Queue Prompt**
