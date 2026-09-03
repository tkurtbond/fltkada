((ada-ts-mode
  . ((eval . (setq-local lsp-ada-project-file
                          (expand-file-name "../tests.gpr" default-directory)))
     (eval . (load (expand-file-name "../ada-ts-mode-fltkada.el" default-directory))))))
