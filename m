From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: cr: fix trivial compile error
Date: Fri, 25 Mar 2011 22:08:10 -0400
Message-ID: <4D8D4A8A.10602@cs.columbia.edu>
References: <20110214021142.GA3158@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110214021142.GA3158@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Pulled for v23-rc2.

Oren.

On 02/13/2011 09:11 PM, Serge E. Hallyn wrote:
> diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
> index 5bff486..6261993 100644
> --- a/fs/sysv/dir.c
> +++ b/fs/sysv/dir.c
> @@ -25,7 +25,6 @@ const struct file_operations sysv_dir_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= sysv_readdir,
>  	.fsync		= generic_file_fsync,
> -	.fsync		= simple_fsync,
>  #ifdef CONFIG_CHECKPOINT
>  	.checkpoint	= generic_file_checkpoint,
>  #endif
> 
