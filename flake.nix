{
  description = "Pierrot's flake templates";

  outputs = {self, ...}: {
    templates = {
      jax = {
        path = ./jax-template;
        description = "JAX project";
      };
      pytorch = {
        path = ./pytorch-template;
        description = "PyTorch project";
      };
    };
  };
}
