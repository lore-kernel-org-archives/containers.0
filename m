From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 3/3] vfs: Fix a regression in mounting proc
Date: Fri, 29 Nov 2013 20:53:27 +0100
Message-ID: <20131129195327.GA12974@redhat.com>
References: <20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <87pppmzoin.fsf_-_@xmission.com>
	<20131127161300.GA24773@redhat.com> <871u21oeyr.fsf@xmission.com>
	<20131127194722.GA32673@redhat.com>
	<87iovdmxl7.fsf@xmission.com> <87wqjtlic3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wqjtlic3.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/27, Eric W. Biederman wrote:
>
> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
>
> > Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> >>
> >> Lets ignore the implementation details. Suppose that proc was never
> >> mounted. Then "mount -t proc" should fail after CLONE_NEWUSER | NEWNS?
> >
> > Yes.
>
> Well strictly speaking it should fail after CLONE_NEWUSER | NEWNS | NEWPID.

Yes, yes, I understand, the mounter should be CAP_SYS_ADMIN in
task_active_pid_ns().

> Has this cleared up the confusion?

Yes. Thanks.

Oleg.
