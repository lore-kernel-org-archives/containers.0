From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 3/3] nsexec: remount proc and devpts
Date: Tue, 16 Feb 2010 14:38:51 +0300
Message-ID: <4B7A83CB.4070009@msgid.tls.msk.ru>
References: <1266274696-23018-1-git-send-email-serue@us.ibm.com>
	<1266274696-23018-4-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266274696-23018-4-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Serge Hallyn wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Add -t as an nsexec option to request new devpts.
> 
> Automatically remount /proc if we are starting a new pidns.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  nsexec.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 48 insertions(+), 2 deletions(-)
> 
> diff --git a/nsexec.c b/nsexec.c
> index 8b96bc9..3a825f1 100644
> --- a/nsexec.c
> +++ b/nsexec.c
..


Please execuse my silly question, but for _what_ this patch is? :)

It does not look like lxc-utils, and it's not in kernel either...

Thanks!

/mjt
