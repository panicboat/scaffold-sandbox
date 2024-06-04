require 'rspec'
require_relative '../src/overlay'

describe 'Oase' do
  let(:env) do
    { workspace: '/app', service: 'service', owner: 'owner', namespace: 'namespace', kind: 'kind', name: 'name', }
  end
  let(:_overlay) { Overlay.new(env[:workspace], env[:service], env[:owner], env[:namespace], env[:kind], env[:name]) }
  let(:kustomization) do
    {
      apiVersion: 'kustomize.config.k8s.io/v1beta1',
      kind: 'Kustomization',
      configMapGenerator: [
        { name: 'rspec-config', options: { disableNameSuffixHash: true } },
      ],
      resources: [
        "#{env[:kind]}/rspec-workflow.yaml",
      ],
      patches: [
        { path: "configmap/rspec-config.yaml" },
      ],
    }
  end

  describe '#_kustomization' do
    it 'returns the correct kustomization (create)' do
      result = _overlay.send(:_kustomization, {}, true)
      expect(result).to be_a(Hash)
      expect(result[:configMapGenerator]).to be_nil
      expect(result[:resources]).to be_nil
      expect(result[:patches]).to be_a(Array)
      expect(result[:patches]).to eq([{path: "configmap/#{env[:name]}.yaml"}, {path:"#{env[:kind]}/#{env[:name]}.yaml"}])
    end

    it 'returns the correct kustomization (add)' do
      result = _overlay.send(:_kustomization, kustomization, true)
      expect(result).to be_a(Hash)
      expect(result[:configMapGenerator]).to be_a(Array)
      expect(result[:configMapGenerator]).to eq(kustomization[:configMapGenerator])
      expect(result[:resources]).to be_a(Array)
      expect(result[:resources]).to eq(kustomization[:resources])
      expect(result[:patches]).to be_a(Array)
      expect(result[:patches]).to eq([{ path: "configmap/rspec-config.yaml" }, { path: "configmap/#{env[:name]}.yaml" }, { path:"#{env[:kind]}/#{env[:name]}.yaml" }])
    end

    it 'returns the correct kustomization (replace)' do
      values = {
        configMapGenerator: [
          {name: env[:name], options: {disableNameSuffixHash: true}},
          { name: 'rspec-config', options: { disableNameSuffixHash: true } },
        ],
        resources: [
          "#{env[:kind]}/#{env[:name]}.yaml",
          "#{env[:kind]}/rspec-workflow.yaml",
        ],
        patches: [
          { path: "configmap/#{env[:name]}.yaml" },
          { path: "configmap/rspec-config.yaml" },
        ],
      }
      result = _overlay.send(:_kustomization, values, true)
      expect(result).to be_a(Hash)
      expect(result[:configMapGenerator]).to be_a(Array)
      expect(result[:configMapGenerator]).to eq(kustomization[:configMapGenerator])
      expect(result[:resources]).to be_a(Array)
      expect(result[:resources]).to eq(kustomization[:resources])
      expect(result[:patches]).to be_a(Array)
      expect(result[:patches]).to eq([{ path: "configmap/rspec-config.yaml" }, { path: "configmap/#{env[:name]}.yaml" }, { path: "#{env[:kind]}/#{env[:name]}.yaml" }])
    end

    it 'returns the correct kustomization (do not create blank patches)' do
      result = _overlay.send(:_kustomization, kustomization, true)
      expect(result).to be_a(Hash)
      expect(result[:configMapGenerator]).to be_a(Array)
      expect(result[:configMapGenerator]).to eq(kustomization[:configMapGenerator])
      expect(result[:resources]).to be_a(Array)
      expect(result[:resources]).to eq(kustomization[:resources])
      expect(result[:patches]).to be_a(Array)
      expect(result[:patches]).to eq(kustomization[:patches])
    end
  end
end