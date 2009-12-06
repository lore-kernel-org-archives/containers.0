From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/3] checkpoint/powerpc: fixes etc
Date: Sun, 06 Dec 2009 14:21:52 -0500
Message-ID: <4B1C0450.3080004@cs.columbia.edu>
References: <1259981307-24936-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259981307-24936-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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


Will fold into ckpt-v19-rc3.

Thanks,

Oren.

Nathan Lynch wrote:
> Hi Oren,
> 
> Here are a few patches against ckpt-v19-rc2 that improve the state of
> checkpoint/restart on powerpc.  Please feel free to fold them into the
> powerpc portion of the patchset.
> 
> Nathan Lynch (3):
>   checkpoint/powerpc: fix 32-bit build
>   checkpoint/powerpc: save and restore nvgprs for checkpoint/restart
>   checkpoint/powerpc: warn if full register state unavailable
> 
>  arch/powerpc/include/asm/systbl.h |    4 ++--
>  arch/powerpc/kernel/entry_32.S    |   23 +++++++++++++++++++++++
>  arch/powerpc/kernel/entry_64.S    |   16 ++++++++++++++++
>  arch/powerpc/kernel/process.c     |    4 ++--
>  arch/powerpc/mm/checkpoint.c      |    2 ++
>  5 files changed, 45 insertions(+), 4 deletions(-)
> 
> 
