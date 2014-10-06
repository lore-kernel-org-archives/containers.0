From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH V5 08/13] sched: add a macro to ref all CLONE_NEW* flags
Date: Mon, 6 Oct 2014 09:21:45 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E5DABA4@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <cover.1412543112.git.rgb@redhat.com>
	<958367f30fb7eddaa406487e63ec1889138ef54f.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <958367f30fb7eddaa406487e63ec1889138ef54f.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



> -----Original Message-----
> From: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> [mailto:containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org] On Behalf Of Richard Guy
> Briggs
> Sent: Monday, October 06, 2014 1:09 PM
> To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org;
> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
> Subject: [PATCH V5 08/13] sched: add a macro to ref all CLONE_NEW* flags
> 
> ---
>  include/uapi/linux/sched.h |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/include/uapi/linux/sched.h b/include/uapi/linux/sched.h
> index 34f9d73..5aceba2 100644
> --- a/include/uapi/linux/sched.h
> +++ b/include/uapi/linux/sched.h
> @@ -28,6 +28,12 @@
>  #define CLONE_NEWUSER		0x10000000	/* New user namespace */
>  #define CLONE_NEWPID		0x20000000	/* New pid namespace */
>  #define CLONE_NEWNET		0x40000000	/* New network namespace */
> +#define CLONE_NEW_MASK	( CLONE_NEWNS \
> +			| CLONE_NEWUTS \
> +			| CLONE_NEWIPC \
> +			| CLONE_NEWUSER \
> +			| CLONE_NEWPID \
> +			| CLONE_NEWNET)	/* mask of all namespace type flags */
>  #define CLONE_IO		0x80000000	/* Clone io context */
> 

The name 'CLONE_NEW_MASK' may confuse readers.
How about something like CLONE_NEW_MASK_ALL?

Thanks,
- Chen
