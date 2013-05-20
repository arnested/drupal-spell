;;; drupal-spell.el --- Aspell extra dictionary for Drupal

;; Copyright (C) 2013  Arne Jørgensen

;; Author: Arne Jørgensen <arne@arnested.dk>
;; URL: https://github.com/arnested/drupal-spell
;; Created: March 22, 2013
;; Version: 0.2.2
;; Keywords: wp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; An extra dictionary for aspell with Drupal specific terminology.

;;; Code:

(require 'ispell)

(defun drupal-spell-find-dictionary (&optional language)
  "Find the `drupal-spell' dictionary. Generate it if necessary."
  (when (null language)
    (setq language "en"))
  ;; Let's set up some temporary variables.
  (let ((dict (expand-file-name (concat (file-name-directory
                                         (or load-file-name buffer-file-name default-directory))
                                        "dict/drupal."
                                        language
                                        ".aspell")))
        (wordlist (expand-file-name (concat (file-name-directory
                                             (or load-file-name buffer-file-name default-directory))
                                            "dict/drupal.txt"))))
    ;; If dictionary exists and is readable return it otherwise return the empty string.
    (if (file-readable-p dict)
        dict
      ;; If the dictionary doesn't exists, but we can read the word
      ;; list and we can find the aspell executable try to generate
      ;; the dictionary.
      (if (and (not (file-exists-p dict))
               (file-exists-p wordlist)
               (executable-find "aspell"))
          (progn
            ;; Generate the dictionary from the word list.
            (call-process (executable-find "aspell") wordlist nil nil "--lang" language "create" "master" dict)
            ;; If the dictionary exists and is readable now return it otherwise return the empty string.
            (if (file-readable-p dict)
                dict
              ""))
            ""))))

(defcustom drupal-spell-extra-dict (drupal-spell-find-dictionary)
  "Location of the Drupal aspell dictionary."
  :type '(file :must-match t)
  :safe t
  :group 'ispell)

;;;###autoload
(defun drupal-spell-enable nil
  "Enable Drupal dictionary as aspell extra dictionary in current buffer."
  (interactive)
  (when ispell-really-aspell
    (add-to-list (make-local-variable 'ispell-extra-args) (concat "--add-extra-dicts=" drupal-spell-extra-dict))))

;;;###autoload
(add-hook 'drupal-mode-hook 'drupal-spell-enable)



(provide 'drupal-spell)

;;; drupal-spell.el ends here
