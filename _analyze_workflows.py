# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json, glob, os

workflow_dir = "C:/Users/jpennington/comfyui-generative-ai-workflows/workflows"
workflow_files = sorted(glob.glob(workflow_dir + '/**/*.json', recursive=True))

path_prefixes = ['/app/', 'C:/Users/', '/home/', '/root/']

for wf_path in workflow_files:
    try:
        with open(wf_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print('ERROR reading {}: {}'.format(wf_path, e))
        continue

    all_nodes = list(data.get('nodes', []))
    defs = data.get('definitions', {})
    for sg in defs.get('subgraphs', []):
        all_nodes.extend(sg.get('nodes', []))

    node_types = sorted(set(n.get('type','') for n in all_nodes))
    aux_ids = sorted(set(
        n.get('properties', {}).get('aux_id', '')
        for n in all_nodes
        if n.get('properties', {}).get('aux_id')
    ))
    cnr_ids = sorted(set(
        n.get('properties', {}).get('cnr_id', '')
        for n in all_nodes
        if n.get('properties', {}).get('cnr_id') and n.get('properties', {}).get('cnr_id') != 'comfy-core'
    ))

    path_flags = []
    placeholder_flags = []
    for n in all_nodes:
        for wv in n.get('widgets_values', []):
            if isinstance(wv, str):
                wv_norm = wv.replace('\\', '/').replace('\', '/')
                has_path = any(p in wv_norm for p in path_prefixes)
                if has_path:
                    path_flags.append((n.get('type'), wv))
                lower = wv.lower()
                if any(p in lower for p in ['placeholder','todo','fixme','dummy','xxx','debug']):
                    placeholder_flags.append((n.get('type'), wv))

    rel = wf_path.replace(workflow_dir + '/', '')
    print('=== {} ==='.format(rel))
    print('  Node types: {}'.format(node_types))
    print('  aux_ids: {}'.format(aux_ids))
    print('  cnr_ids (non-core): {}'.format(cnr_ids))
    if path_flags:
        print('  *** HARDCODED PATHS: {}'.format(path_flags))
    else:
        print('  Hardcoded paths: none')
    if placeholder_flags:
        print('  *** PLACEHOLDER VALUES: {}'.format(placeholder_flags))
    print()
