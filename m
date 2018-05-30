From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 0/6] Wrapping up the vfs support for unprivileged
	mounts
Date: Tue, 29 May 2018 21:34:35 -0500
Message-ID: <87k1rlkh1g.fsf@xmission.com>
References: <87o9h6554f.fsf@xmission.com> <20180524214617.GG7712@thunk.org>
	<87y3g8y6x9.fsf@xmission.com> <20180525035716.GE10363@dastard>
	<8736yar4g3.fsf@xmission.com> <20180529221710.GM23861@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180529221710.GM23861@dastard> (Dave Chinner's message of "Wed,
	30 May 2018 08:17:10 +1000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: "Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org> writes:

> Yeah, the are some fairly big process and policy things that need
> to be decided here. Not just at the kernel level, but at distro and
> app infrastructure level too.
>
> I was originally sceptical of supporting kernel filesystems via lkl,
> but the desire for unprivileged mounts has not gone away and so I'm
> less worried about accessing filesystems that way than I am of
> letting the kernel parse untrusted images from untrusted users...

There is also the more readily available libguestfs which doesn't
support as many filesystems but does seem available in most
linux distributions already.  It already has a fuse option available
with guestmount.  I may have to dig in there and see how to make
it available without using fusermount.

> I'm not sure what the correct forum for this is - wasn't this
> something the Plumbers conference was supposed to facilitate?

Yes.  If we all need to be in a room and talk about things.
It is early enough in the planning for Plumers that we could
definitely schedule a talk or a BOF for this.

>> Is fusefs-lkl valuable for testing filesystems?  If xfs-tests were to
>> have a mode that used that used the fuse protocol for testing and
>> fuzzing filesystems without the full weight of the kernel in the middle
>> that might encourage people to suppor this kind of things as well.
>
> Getting lkl-fuse to run under fstests would be a great way to ensure
> we have some level of confidence that it will do the right thing and
> users can expect that it won't eat their data. I think this would
> need to be a part of a recommendation for wider deploy of such a
> solution...

Good thought.  I will have to give that a look.  That does sound like a
good practical test.

Eric
