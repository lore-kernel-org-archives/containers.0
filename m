From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [REVIEW][PATCH] vfs: Lock in place mounts from more privileged
	users
Date: Wed, 24 Jul 2013 08:46:45 -0700
Message-ID: <CALCETrWCxny906McvR9gjn6cqXvO4Mjp3gGPKDnWbYd4ocBmcw__46440.6396415599$1374680840$gmane$org@mail.gmail.com>
References: <877gghruwq.fsf@xmission.com>
	<CALCETrXXGhVbkG6AnRck+W1kMns5TJuNYAqe_tV44JvWgDoUzA@mail.gmail.com>
	<87li4wpi2b.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87li4wpi2b.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 23, 2013 at 11:50 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>> On Tue, Jul 23, 2013 at 11:30 AM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>
>>> When creating a less privileged mount namespace or propogating mounts
>>> from a more privileged to a less privileged mount namespace lock the
>>> submounts so they may not be unmounted individually in the child mount
>>> namespace revealing what is under them.
>>
>> I would propose a different rule: if vfsmount b is mounted on vfsmount
>> a, then to unmount b, you must be ns_capable(CAP_SYS_MOUNT) on either
>> a's namespace or b's namespace.  The idea is that you should be able
>> to see under a mount if you own the parent (because it's yours) or if
>> you own the child (because you, or someone no more privileged than
>> you, put it there).  This may result in a simpler patch and should do
>> much the same thing.
>
> It definitely won't result in a simpler patch as the information you are
> basing the decision on is not available.
>

Ah, I see -- mnt_ns gets changed when the namespace is duplicated.

Acked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>

--Andy
