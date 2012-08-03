From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] Forbid invocation of kexec_load() outside initial PID
	namespace
Date: Fri, 03 Aug 2012 06:07:36 -0700
Message-ID: <bef31b2b-429b-4b2b-981b-b230f9c6bfad@email.android.com>
References: <1343991184-3619-1-git-send-email-berrange@redhat.com>
	<cfa2e2c9-db52-40cd-979b-7a6084427190@email.android.com>
	<20120803125210.GD12870@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120803125210.GD12870-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

"Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

>On Fri, Aug 03, 2012 at 05:45:40AM -0700, Eric W. Biederman wrote:
>> The solution is to use user namespaces and to only test ns_capable on
>the magic reboot path.
>> 
>> For the 3.7 timeframe that should be a realistic solution.
>
>Hmm, that would imply that if LXC wants to allow reboot()/CAP_SYS_BOOT
>they will be forced to use CLONE_NEWUSER. I was rather looking for a
>way
>to allow the container to keep CAP_SYS_BOOT, without also mandating use
>of user namespaces.

If we remove the use of CAP_SYS_BOOT on the container reboot path perhaps.

But you have hit one small issue in the huge pile of issues why giving contaners capabilities is generally a bad idea.

This is the reason I have been insisting on a reasonable version of user namespaces for a long time.

When the security issues become important it is time for user namespaces.   That is their purpose.

Eric
