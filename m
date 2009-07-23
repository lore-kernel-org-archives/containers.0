From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][user-cr]: Fix typo in -lpthread
Date: Wed, 22 Jul 2009 20:58:34 -0400
Message-ID: <4A67B5BA.2010609@librato.com>
References: <20090722202837.GA18639@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722202837.GA18639-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> From 55cb828036ff604fc9cdf686b51afb35247c8f57 Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <suka@suka.(none)>
> Date: Wed, 22 Jul 2009 13:22:38 -0700
> Subject: [PATCH] Fix typo in -lpthread
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  Makefile |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index 53e3a46..3dbc63d 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -44,7 +44,7 @@ all: $(PROGS)
>  
>  ckptinfo: ckptinfo_types.o
>  
> -mktree:	CFLAGS += -D__REENTRANT -pthreads
> +mktree:	CFLAGS += -D__REENTRANT -lpthread

Hmmm .. I actually meant '-pthread' which is a gcc option. I thought
it is better to use it than '-lpthread' directly. For instance, see:
http://stackoverflow.com/questions/875789/gcc-do-i-need-dreentrant-with-pthreads

(seems like '-pthreads' is a synonym, at least on x86).

Does it break on your system ?

Oren.

>  
>  ckptinfo_types.o: ckptinfo_types.c
>  	@echo $(CC) -c $(CFLAGS) $<
