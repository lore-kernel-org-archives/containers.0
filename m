From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 12/16] userns: For /proc/self/{uid,
	gid}_map derive the lower userns from the struct file
Date: Mon, 19 Nov 2012 13:27:45 -0800
Message-ID: <87y5hxxoz2.fsf@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
	<1353337961-12962-12-git-send-email-ebiederm@xmission.com>
	<20121119180322.GC1883@serge-ThinkPad-X130e>
	<87fw451m5i.fsf@xmission.com> <20121119210153.GA11904@sergelap>
	<877gphz4d9.fsf@xmission.com> <20121119211912.GA12388@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121119211912.GA12388@sergelap> (Serge Hallyn's message of
	"Mon, 19 Nov 2012 15:19:12 -0600")
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
>> 
>> In practice when playing around it is the difference between.
>> unshare -U /bin/bash
>> echo 0 1000 1 > /proc/self/uid_map
>> 
>> And the need to pre-plan something.  You can set the uid_map from the
>> parent in a shell script but it is a real pain.  So for just messing
>> around allowing seq_ns == ns is a real advantage.
>
> Heh, ok - I almost always want >1 uid mapped, but I can see the
> advantage.

The original plan called for an upcall and >1 uid mapped.  But yeah
that is something else again.

> Thanks.
>
> I don't recall whether I put this in originally, but
>
> Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
>
>> > I also wonder if -EINVAL would be a more appropriate choice here.
>> > We're trying to keep things sane, rather than saying "not allowed"
>> > for its own sake.
>> 
>> A different error code might be better.
>
> I suppose strictly speaking (looking at errno-base.h) it would be
> EBADF?

Definitely not EBADF.  EBADF is the error code for operating on a closed
file descriptor.

I want a ENOTALLOWED. Anyway.

Eric
