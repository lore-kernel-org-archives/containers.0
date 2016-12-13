From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [inotify] fee1df54b6:
	BUG_kmalloc-#(Not_tainted):Freepointer_corrupt
Date: Wed, 14 Dec 2016 07:51:39 +1300
Message-ID: <87oa0fpsqs.fsf@xmission.com>
References: <87inqo4ip1.fsf@yhuang-dev.intel.com>
	<db529280-24ec-9957-93bc-b42998e1d692@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <db529280-24ec-9957-93bc-b42998e1d692-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Nikolay
	Borisov's message of "Tue, 13 Dec 2016 18:56:25 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> So this thing resurfaced again and I took a hard look into the code but
> couldn't find anything suspicious. So the allocating and freeing
> contexts leads me to believe it's the 'tbl' pointer that is being
> corrupted. The only thing which I do with it is to increase it by two.
>
> Perhaps some liveness issues.

To me it feels like a double free somewhere.  Like we call dec_ucount
and thus put_ucount multiple times in a way that goes to 0.

Perhaps there is a peculiarity in the existing code which allows the
count to go to zero which we don't notice because we don't free anything
when the count goes to zero today.

Perhaps there is some subtle semantic mismatch between your conversion
and the inotify code.

I don't know if you made a subtle misreading of the code, or if
there is an existing bug that your changes took from harmless to
problematic, but the evidence is overwhelming that something
is going wrong and it is your patch that brings it out.

If it helps the openvz folks apparently reproduced this with the criu
regression tests and the appropriate kernel debug options, and confirmed
the failure was your patch.

The current state of play is that I would love to merge this if we can
track down this issue.  I dropped this from my tree before I sent my pull
request to Linus so there is no emergency to get this fixed.

Eric
