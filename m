From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: For review: pid_namespaces(7) man page (draft 2)
Date: Tue, 12 Mar 2013 14:43:58 -0700
Message-ID: <871ubkz42p.fsf@xmission.com>
References: <CAKgNAkgAT8vFr7hbEzOjJG5pCt8-kh_4Wh9yrzHHXrCJ3Fhh+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAKgNAkgAT8vFr7hbEzOjJG5pCt8-kh_4Wh9yrzHHXrCJ3Fhh+w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Michael Kerrisk's message of "Tue, 12 Mar 2013 08:07:30 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

"Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Eric et al.,
>
> [CCing Li because of reboot(2) changes]
>
> I have (I think) addressed all previous comments in the current draft
> of the pid_namespaces(7) page. This is a final sanity check before I
> call this page complete (modulo any future kernel changes).

Baring the 3.9 reference to reboot(2) which should be 3.4 I don't see
any problems.

I think you have reached the point where if there are any problems left
I will just have to send you patches after you publish because my eyes
are glassing over and I am not going to see any more problems right now.

One of those patches I am going to have to send you is I am fixing the
case below for 3.10
>            clone(..., CLONE_VM, ...);
>            setns(fd, CLONE_NEWPID);      /* Fails */
>
>            clone(..., CLONE_VM, ...);
>            unshare(CLONE_NEWPID);        /* Fails */
>
It turns out that the check in fork/clone is sufficient.

The verbage about all of the namespaces is correct however since
unshare(CLONE_NEWPID) doesn't actually change the pid_namespace it
doesn't matter.

Eric
