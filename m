From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 0/1][NETNS49] Make af_unix autobind per namespace
Date: Tue, 02 Oct 2007 16:43:38 -0600
Message-ID: <m1myv1gmsl.fsf@ebiederm.dsl.xmission.com>
References: <20071002151846.827206013@mai.toulouse-stg.fr.ibm.com>
	<m1fy0tjv04.fsf@ebiederm.dsl.xmission.com>
	<4702AF67.1010707@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4702AF67.1010707-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Tue,
	02 Oct 2007 22:51:51 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> The following patch change autobind fonction to use the ordernum
>>> from the network namespace instead of using the local static variable.
>>
>> Why do we care?
>> Information leak?
>> Some application is expecting a predictable autobind value?
>>
>> Just skimming the code it looks like it will work correctly without
>> this.
>
> I think my summary is ... too short :)
>
> I don't see any applications taking care of this. If they ask for an abstract
> socket, then they don't care about the bind result. So probably, the patchset is
> totally useless.
>
> But from the POV of the checkpoint/restart, we should check if this value is
> somewhere visible from userspace and so storable by an application.

Right.  And we already can already specifically select this result.
My point is that the semi random sequence generator logic does not
need to be per namespace, because people don't care what the sequence.
That sequence is not exported to user space.

> It appears this is the case with /proc/net/unix, where an abstract socket is
> symbolized by the path pattern "@". Example:
>
> cat /proc/net/unix
>
> Num       RefCount Protocol Flags    Type St Inode Path
> c6a27710: 00000002 00000000 00000000 0002 01  4357 @00003

Right, and that part we should definitely preserve for checkpoint/restart
purposes.

> I agree by the fact that can be considered as a detail and the probability to
> have an application storing this informaton is very small ( eg. checkpointing
> while doing netstat in the container ). But IMHO, the paradigm "never seen from
> userspace" fails and that justifies to have the ordernum variable relative to a
> namespace.

My point was that ordernum itself is not seen.  It is just an arbitrary number
and we are allowed to change the algorithm for selecting a new abstract
namespace name at will.

If there is something in userspace that depends on the algorithm for selecting
the abstract name then making ordernum per namespace make sense.

At the moment the code is simpler to use what is effectively a different
algorithm for selecting the abstract namespace name of the socket.

Eric
