# ==============================================================================
# config - initializers - 000 sorbet runtime
# ==============================================================================
require 'sorbet-runtime'
Method.prepend(T::CompatibilityPatches::MethodExtensions)