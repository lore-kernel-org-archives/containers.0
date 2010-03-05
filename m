From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cr_tests: Use toolchain prefixes and variables in
	Makefiles
Date: Fri, 5 Mar 2010 12:08:43 -0600
Message-ID: <20100305180843.GA23409@us.ibm.com>
References: <8b495c1ce49380d01a34fc2e3ccf0e27802306f3.1267771287.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8b495c1ce49380d01a34fc2e3ccf0e27802306f3.1267771287.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Applied, thanks.

-serge

> ---
>  Makefile         |    7 +++++++
>  eventfd/Makefile |    4 ++--
>  futex/module.mk  |    2 +-
>  pty/Makefile     |    2 +-
>  selinux/Makefile |    2 +-
>  5 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index e8eb048..f17a9be 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -23,6 +23,13 @@ override CFLAGS += -Wall
> 
>  all:
> 
> +# Prefix CC, AS, LD, AR for cross compilation
> +CROSS_COMPILE ?=
> +CC ?= $(CROSS_COMPILE)gcc
> +LD ?= $(CROSS_COMPILE)ld
> +AS ?= $(CROSS_COMPILE)as
> +AR ?= $(CROSS_COMPILE)ar
> +
>  include $(addsuffix /module.mk,$(modules))
> 
>  progs += mysu
> diff --git a/eventfd/Makefile b/eventfd/Makefile
> index 82456e8..1bcd587 100644
> --- a/eventfd/Makefile
> +++ b/eventfd/Makefile
> @@ -13,10 +13,10 @@ all: $(PROGS)
>  	$(MAKE) -C ../libcrtest libcrtest.a
> 
>  libeptest.a: libeptest.o libeptest.h
> -	ar cr libeptest.a libeptest.o
> +	$(AR) cr libeptest.a libeptest.o
> 
>  $(PROGS): %: %.c $(LIBS)
> -	gcc -Wall $(CFLAGS) -o $@ $< $(LIBS)
> +	$(CC) -Wall $(CFLAGS) -o $@ $< $(LIBS)
> 
>  clean:
>  	rm -f *.o libeptest.a $(PROGS)
> diff --git a/futex/module.mk b/futex/module.mk
> index 6ab0449..412216b 100644
> --- a/futex/module.mk
> +++ b/futex/module.mk
> @@ -1,7 +1,7 @@
>  local_dir := futex
>  local_progs := $(addprefix $(local_dir)/,plain robust pi)
> 
> -MACHINE := $(shell gcc -dumpmachine)
> +MACHINE := $(shell $(CC) -dumpmachine)
>  ifeq ($(MACHINE:i386-%=i386),i386)
>  ARCHOPTS := -march=i486
>  endif
> diff --git a/pty/Makefile b/pty/Makefile
> index fe93a00..438f9bc 100644
> --- a/pty/Makefile
> +++ b/pty/Makefile
> @@ -6,7 +6,7 @@ SLIBS = ../libcrtest/libcrtest.a
>  LIBCMD = -I../libcrtest -L../libcrtest $(SLIBS)
> 
>  ptyloop: ptyloop.c ../clone.h $(SLIBS)
> -	gcc -o ptyloop ptyloop.c $(LIBCMD)
> +	$(CC) -o ptyloop ptyloop.c $(LIBCMD)
> 
>  clean:
>  	rm -f $(targets) out* ckpt-out read-ok read-bad
> diff --git a/selinux/Makefile b/selinux/Makefile
> index 2ae8d96..f96384d 100644
> --- a/selinux/Makefile
> +++ b/selinux/Makefile
> @@ -3,7 +3,7 @@ targets = ckpt wrap
>  all: $(targets)
> 
>  ckpt: ckpt.c ../cr.h
> -	gcc -o ckpt ckpt.c
> +	$(CC) -o ckpt ckpt.c
> 
>  clean:
>  	rm -rf $(targets) out context cr-test.out cr-test-module restart wrap
> -- 
> 1.6.3.3
