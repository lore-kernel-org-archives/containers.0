From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Tue, 19 May 2015 10:27:30 -0400
Message-ID: <CAHC9VhTHj24cjFE9imjm5C8FLvykF70ZvziC7s7pvMmpZED-vA__45474.4947528981$1432045989$gmane$org@mail.gmail.com>
References: <cover.1429252659.git.rgb@redhat.com>
	<20150515023221.GC965@madcap2.tricolour.ca>
	<CALCETrWzM4+Vs8OVJWBcWJfbR_DRSb+e7SmUyy6CS4sHQaTkRw@mail.gmail.com>
	<9125391.7ZiCneo6Xn@sifl> <555711FA.50703@redhat.com>
	<CAHC9VhRKSK9=9qPF3dgALS=x1g3LinNeQvuhNV5TvQ=D7Szuag@mail.gmail.com>
	<87r3qgpol6.fsf@x220.int.ebiederm.org>
	<CAHC9VhQs6pxFC3dvZic5XzuJr1xdJZyPjXdBoipwY3OOkng0ng@mail.gmail.com>
	<20150519130911.GB20131@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150519130911.GB20131-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, May 19, 2015 at 9:09 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 15/05/16, Paul Moore wrote:
>> On Sat, May 16, 2015 at 10:46 AM, Eric W. Biederman wrote:
>> > It sounds nice but containers are not just a per process construct.
>> > Sometimes you might know anamespace but not which process instigated
>> > action to happen on that namespace.
>>
>> From an auditing perspective I'm not sure we will ever hit those
>> cases; did you have a particular example in mind?
>
> The example that immediately came to mind when I first read Eric's
> comment was a packet coming in off a network in a particular network
> namespace.  That could narrow it down to a subset of containers based on
> which network namespace it inhabits, but since it isn't associated with
> a particular task yet (other than a kernel thread) it will not be
> possible to select the precise nsproxy, let alone the container.

Thanks, I was stuck thinking about syscall based auditing and forgot
about the various LSM based audit records.  Of all people you would
think I would remember per-packet audit records ;)

Anyway, in this case I think including the namespace ID is sufficient,
largely because the container userspace doesn't have access to the
packet at this point.  In order to actually receive the data the
container's userspace will need to issue a syscall where we can
include the container ID.  An overly zealous security officer who
wants to trace all the kernel level audit events, like the one you
describe, can match up the namespace to a container in post-processing
if needed.

-- 
paul moore
www.paul-moore.com
