Copyright (C) Juan Miguel Cejuela <juanmi@jmcejuela.com>

--------------------------------------------------------------------------------
CL-HMM: Simple HMM Library for Common Lisp
--------------------------------------------------------------------------------

Compatibility: ANSI Common Lisp. All OS with a Lisp implementation.
               Tested on SBCL 1.1.11 and Allegro 8.0 Free Express Edition
Dependencies: jmc.cl.utils system
Originally Created:    Wed Jul  9 18:18:18 2008 (CEST)
Last Effective Update: Mon Sep 22 13:03:46 2008 (CEST)



Features:
--------------------------------------------------------------------------------

* Discrete observation densities
* Exponential state duration densities
* Homogeneous HMMs. First order
* Tied emission parameters
* Finite and infinite HMMs
* Begin state/s modeled in the initial state distribution
* Not explicit begin/end states
* Forward/Backward scaled, Viterbi in log
* Baum-Welch for multiple labeled sequences, with normalized noise
* Alphabet symbols of any kind
* Comparable efficiency to GHMM written in C (1x - 2x slower)



Files Definition:
--------------------------------------------------------------------------------

* cl-hmm.asd: System definer
* packages: package definer
* cl-hmm.lisp: Head archive. Compiler definitions. Constant definitions. Macro to define hmms. Definition of common methods for the hmms
* utilities: specific utilities for the library
* hmm-simple: specification for the hmm type simple (infinite and finite)
* for&back-ward: forward and backward algorithms
* viterbi: viterbi algorithms
* baum-welch: baum-welch algorithms
* alphabets: a set of alphabets recognized by the library
* hmm-files: manager of .hmm files



Comments:
--------------------------------------------------------------------------------

- Followed in code Rabiner's notation. Otherwise properly indicated.
