From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: add a few more ckpt_write_err()s
Date: Mon, 14 Sep 2009 08:24:44 -0500
Message-ID: <20090914132444.GA5379@us.ibm.com>
References: <20090910223344.GA11718@us.ibm.com> <4AAABE01.1080807@librato.com>
	<20090911212742.GB15329@us.ibm.com> <4AAE3B47.9020106@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AAE3B47.9020106-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> Serge E. Hallyn wrote:
> > 
> > Yes, it'd be useful.  BTW it also would be useful to have mktree/
> > restart auto-detect such error strings and report them.
> > 
> 
> 'ckptinfo -e' should already do this, but sure, we can add a switch

Oh, ha, I wouldn't know, bc ckptinfo has never compiled for me, and
I'd never yet cared to beat it into compiling.

Looks like it will work for me if I do

	export KERNELHDR=/usr/include

in my shell before compiling, and use the following patch:

diff --git a/Makefile b/Makefile
index afff3f5..f7bd93b 100644
--- a/Makefile
+++ b/Makefile
@@ -48,7 +48,7 @@ mktree:       CFLAGS += -D__REENTRANT -pthread
 
ckptinfo_types.o: ckptinfo_types.c
	@echo $(CC) -c $(CFLAGS) $<
-	@$(CC) -c $(CFLAGS) $<
+	@$(CC) -D__GLIBC__=2 -c $(CFLAGS) $<
 
 ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
	@echo cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c


> to 'restart' to check it too. An dyes, in the kernel definitely.
> 
> Oren.
