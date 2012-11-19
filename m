From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 12/16] userns: For /proc/self/{uid,
	gid}_map derive the lower userns from the struct file
Date: Mon, 19 Nov 2012 13:09:54 -0800
Message-ID: <877gphz4d9.fsf@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
	<1353337961-12962-12-git-send-email-ebiederm@xmission.com>
	<20121119180322.GC1883@serge-ThinkPad-X130e>
	<87fw451m5i.fsf@xmission.com> <20121119210153.GA11904@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121119210153.GA11904@sergelap> (Serge Hallyn's message of
	"Mon, 19 Nov 2012 15:01:53 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>> 
>> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> >> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> >> 
>> >> To keep things sane in the context of file descriptor passing derive the
>> >> user namespace that uids are mapped into from the opener of the file
>> >> instead of from current.
>> >> 
>> >> When writing to the maps file the lower user namespace must always
>> >> be the parent user namespace, or setting the mapping simply does
>> >> not make sense.  Enforce that the opener of the file was in
>> >> the parent user namespace or the user namespace whose mapping
>> >> is being set.
>> >
>> > Is there a reasonable use case for writing from the ns whose mapping
>> > is being set?  Are you expecting cases where the child opens the file
>> > and passes it back to the parent to set the mappings?
>> 
>> Passing the open mappings file no.  Although by using seq_user_ns I do
>> make certain the semantics are correct if the file descriptor is passed,
>> but I did that on general principles.
>> 
>> I expect a process in the user namespace to be able to meaningfully set
>> the mapping to some the current uid and the current gid.
>
> Sorry, I think a word is missing there.  To be precise (bc I haven't
> thought about this much before as it's not my target goal :) you're
> saying if I'm uid 1000 gid 1000, I can create a new user namespace
> and, from inside that new userns (where I'm first uid/gid -1) I can
> map any uid+gid in the container to 1000 in the parent ns?  Or is there
> something more?

Only that for now.  I had once imagined magic would happen in the
background to verify the parent.

> It still seems to me no less flexible to require being in the parent
> ns, so
>
>> >> +	if ((seq_ns != ns) && (seq_ns != ns->parent))
>> >> +		return -EPERM;
>
> would become
>
>> >> +	if (seq_ns != ns->parent)
>> >> +		return -EPERM;
>

In practice when playing around it is the difference between.
unshare -U /bin/bash
echo 0 1000 1 > /proc/self/uid_map

And the need to pre-plan something.  You can set the uid_map from the
parent in a shell script but it is a real pain.  So for just messing
around allowing seq_ns == ns is a real advantage.

> I also wonder if -EINVAL would be a more appropriate choice here.
> We're trying to keep things sane, rather than saying "not allowed"
> for its own sake.

A different error code might be better.

Eric
