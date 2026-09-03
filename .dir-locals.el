((ada-ts-mode
  . ((eval . (setq-local lsp-ada-project-file
                          (expand-file-name "fltkada.gpr"
                            (locate-dominating-file default-directory ".dir-locals.el"))))
     (eval . (load (expand-file-name "ada-ts-mode-fltkada.el"
                     (locate-dominating-file default-directory ".dir-locals.el"))))))
 (c++-mode
  . ((eval . (load (expand-file-name "cc-mode-fltkada.el"
                     (locate-dominating-file default-directory ".dir-locals.el"))))))
 (c-mode
  . ((eval . (load (expand-file-name "cc-mode-fltkada.el"
                     (locate-dominating-file default-directory ".dir-locals.el")))))))
