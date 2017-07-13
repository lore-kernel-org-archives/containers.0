From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Thu, 13 Jul 2017 13:05:47 -0400
Message-ID: <29fdda5e-ed4a-bcda-e3cc-c06ab87973ce__32676.3494093486$1499965611$gmane$org@linux.vnet.ibm.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com> <20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
	<74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
	<20170713011554.xwmrgkzfwnibvgcu@thunk.org>
	<87y3rscz9j.fsf@xmission.com>
	<20170713164012.brj2flnkaaks2oci@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170713164012.brj2flnkaaks2oci-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, christian.brauner-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org, amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/13/2017 12:40 PM, Theodore Ts'o wrote:
> On Thu, Jul 13, 2017 at 07:11:36AM -0500, Eric W. Biederman wrote:
>> The concise summary:
>>
>> Today we have the xattr security.capable that holds a set of
>> capabilities that an application gains when executed.  AKA setuid root exec
>> without actually being setuid root.
>>
>> User namespaces have the concept of capabilities that are not global but
>> are limited to their user namespace.  We do not currently have
>> filesystem support for this concept.
> So correct me if I am wrong; in general, there will only be one
> variant of the form:
>
>     security.foo@uid=15000
>
> It's not like there will be:
>
>     security.foo@uid=1000
>     security.foo@uid=2000

A file shared by 2 containers, one mapping root to uid=1000, the other 
mapping root to uid=2000, will show these two xattrs on the host 
(init_user_ns) once these containers set xattrs on that file.

>
> Except.... if you have an Distribution root directory which is shared
> by many containers, you would need to put the xattrs in the overlay
> inodes.  Worse, each time you launch a new container, with a new
> subuid allocation, you will have to iterate over all files with
> capabilities and do a copy-up operations on the xattrs in overlayfs.
> So that's actually a bit of a disaster.

Note that we do keep compatibility to existing behavior. The 
security.foo of the host is visible inside any container for as long as 
the container root user doesn't set its own security.foo on that file, 
which then hides it. Does that address this concern?


>
> So for distribution overlays, you will need to do things a different
> way, which is to map the distro subdirectory so you know that the
> capability with the global uid 0 should be used for the container
> "root" uid, right?
>
> So this hack of using security.foo@uid=1000 is *only* useful when the
> subcontainer root wants to create the privileged executable.  You
> still have to do things the other way.
>
> So can we make perhaps the assertion that *either*:
>
>     security.foo
>
> exists, *or*
>
>     security.foo@uid=BAR
>
> exists, but never both?  And there BAR is exclusive to only one
> instances?

In the current implementation BAR is visible inside of any instance that 
'covers' this uid with the mapping range. Above example of 
security.foo@uid=1000 appears as security.foo inside the container with 
root mapping to uid 1000 (@uid=0 is suppressed) but also appears as 
security.foo@uid=100 with root uid mapping to 900 (and range of at least 
101).

>
> Otherwise, I suspect that the architecture is going to turn around and
> bite us in the *ss eventually, because someone will want to do
> something crazy and the solution will not be scalable.

Can you define what 'scalable' means for you in this context?
 From what I can see sharing a filesystem between multiple containers 
doesn't 'scale well' for virtualizing the xattrs primarily because of 
size limitations of xattrs per file.

      Stefan

>
> 	  	    		      	   -Ted
>
