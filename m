From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/5] user-cr fixes and generic stack API
Date: Sun, 06 Dec 2009 14:21:00 -0500
Message-ID: <4B1C041C.40903@cs.columbia.edu>
References: <1259989351-28552-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259989351-28552-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Alright, pulled.

Thanks,

Oren.

Nathan Lynch wrote:
> Hi Oren,
> 
> Here's a patch series against ckpt-v19-rc2 that fixes a couple of
> minor issues for powerpc and adds a generic stack API ("genstack").
> 
> Nathan Lynch (5):
>   catch attempts to build clone_ppc_.S in 64-bit mode
>   user-cr: align powerpc sp for eclone, clean up __eclone
>   user-cr: add generic stack API
>   user-cr: use genstack API in restart.c
>   user-cr: use genstack API in nsexeccwp
> 
>  Makefile     |    4 +-
>  clone_ppc.c  |   12 ++++--
>  clone_ppc_.S |   44 +++++++++++--------------
>  genstack.c   |  101 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  genstack.h   |   22 ++++++++++++
>  nsexeccwp.c  |   11 +++---
>  restart.c    |   42 ++++++++++++------------
>  7 files changed, 180 insertions(+), 56 deletions(-)
>  create mode 100644 genstack.c
>  create mode 100644 genstack.h
> 
> 
