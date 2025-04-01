{
  description = "Pierrot's flake templates";

  outputs = {self, ...}: {
    templates = {
      pytorch = {
        path = ./pytorch-template;
        description = "PyTorch project";
      };
    };
  };
}
