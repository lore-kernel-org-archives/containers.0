From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Sat, 16 May 2015 08:16:55 -0400
Message-ID: <CAHC9VhRKSK9=9qPF3dgALS=x1g3LinNeQvuhNV5TvQ=D7Szuag__14906.2780350961$1431779115$gmane$org@mail.gmail.com>
References: <cover.1429252659.git.rgb@redhat.com>
	<20150515023221.GC965@madcap2.tricolour.ca>
	<CALCETrWzM4+Vs8OVJWBcWJfbR_DRSb+e7SmUyy6CS4sHQaTkRw@mail.gmail.com>
	<9125391.7ZiCneo6Xn@sifl> <555711FA.50703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <555711FA.50703-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, May 16, 2015 at 5:46 AM, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 05/15/2015 05:05 PM, Paul Moore wrote:
>> On Thursday, May 14, 2015 11:23:09 PM Andy Lutomirski wrote:
>>> On Thu, May 14, 2015 at 7:32 PM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>>> On 15/05/14, Paul Moore wrote:
>>>>> * Look at our existing audit records to determine which records should
>>>>> have
>>>>> namespace and container ID tokens added.  We may only want to add the
>>>>> additional fields in the case where the namespace/container ID tokens are
>>>>> not the init namespace.
>>>> If we have a record that ties a set of namespace IDs with a container
>>>> ID, then I expect we only need to list the containerID along with auid
>>>> and sessionID.
>>> The problem here is that the kernel has no concept of a "container", and I
>>> don't think it makes any sense to add one just for audit.  "Container" is a
>>> marketing term used by some userspace tools.
>>>
>>> I can imagine that both audit could benefit from a concept of a
>>> namespace *path* that understands nesting (e.g. root/2/5/1 or
>>> something along those lines).  Mapping these to "containers" belongs
>>> in userspace, I think.
>> It might be helpful to climb up a few levels in this thread ...
>>
>> I think we all agree that containers are not a kernel construct.  I further
>> believe that the kernel has no business generating container IDs, those should
>> come from userspace and will likely be different depending on how you define
>> "container".  However, what is less clear to me at this point is how the
>> kernel should handle the setting, reporting, and general management of this
>> container ID token.
>>
> Wouldn't the easiest thing be to just treat add a containerid to the
> process context like auid.

I believe so.  At least that was the point I was trying to get across
when I first jumped into this thread.

> Then make it a privileged operation to set it.  Then tools that care about
> auditing like docker can set the ID
> and remove the Capability from it sub processes if it cares.  All
> processes adopt parent processes containerid.
> Now containers can be audited and as long as userspace is written
> correctly nested containers can either override the containerid or not
> depending on what the audit rules are.

This part I'm still less certain on.  I agree that setting the
container ID should be privileged in some sense, but the kernel
shouldn't *require* privilege to create a new container (however the
user chooses to define it).  Simply requiring privilege to set the
container ID and failing silently may be sufficient.

-- 
paul moore
www.paul-moore.com
