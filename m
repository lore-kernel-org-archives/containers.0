From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Sun, 25 Jun 2017 08:28:45 -0500
Message-ID: <87zicwb3hu.fsf@xmission.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<CAOQ4uxj=_Riih1K+QOYasZU8vZKCSrsg393f=17mJ2O-909e=Q@mail.gmail.com>
	<20170623160026.GA18257@mail.hallyn.com>
	<aa62373e-7cd6-39dd-2e38-2b6d6dbe18a8@schaufler-ca.com>
	<20170623163030.GA18820@mail.hallyn.com>
	<1498237641.3641.15.camel@HansenPartnership.com>
	<20170623172016.GA19551@mail.hallyn.com>
	<553a72c4-eda9-52d6-2ae2-f8687c0c7c70@suse.de>
	<87lgogdz2t.fsf@xmission.com>
	<f1716e8c-dba8-a051-6bc7-285f13ffcaf0@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f1716e8c-dba8-a051-6bc7-285f13ffcaf0-l3A5Bk7waGM@public.gmane.org> (Aleksa Sarai's
	message of "Sun, 25 Jun 2017 23:06:09 +1000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:

>>>>> So my essential point is that building the real kuid into the permanent
>>>>> record of the xattr damages image portability, which is touted as one
>>>>> of the real advantages of container images.
>>>>
>>>> 'container images' aren't portable in that sense now - for at least
>>>> many cases - because you have to shift the uid.  However you're doing
>>>> that, you may be able to shift the xattr the same way.
>>>
>>> Piling more things on top of that issue isn't going to make the issue easier to
>>> solve IMO. Would shiftfs or shift-bindmounts also have to do translation of
>>> arbitrary xattrs? Plus I would think that handling xattrs would be harder than
>>> {u,g}ids because the image unpacker now has to be aware of all xattrs that
>>> require remapping (Which might be an ever-growing list).
>>>
>>> The user namespace incompatibility with the VFS's hard-coding of k{u,g}id values
>>> in inodes is an issue that we really shouldn't be encouraging IMO [especially
>>> given how hard it's been so far to solve that problem.]
>>
>> There is one very simple solution to the problem.
>>
>> Perform the unpacking in your user namespace.
>
> I'm not aware of any major container runtime that couples image
> unpacking to the runtime components. Docker hasn't done it for years
> (it's split between runc and Docker/containerd). rkt hasn't ever done
> it (runtime stages are totally separate to image unpacking). cri-o
> doesn't do it either. I believe that only singularity does something
> like that (though singularity is also not actually a "container
> runtime" in the modern meaning of the term).
>
> Not to mention that the OCI standards explicitly separate the two
> concepts, and there exist tools to manipulate images that don't
> explicitly use containers (or namespaces for that matter) either[1].

It doesn't require coupling it just requires knowing which uids and
gids (from the filesystem perspective) your images are going to use
when you unpack them.

Fundamentally these must be persistent assignments as the uids and gids
persist on disk.  Anything else is not safe.

Knowing those persistent assignments you can unpack an image.  And you
can setup an appropriate user namespace for the unpacking.

And all of that can work as an unprivileged user if done carefully.
Which should reduce the possibility of danger.


>> The reason Docker doesn't do that is they want to share files and images
>> between different containers.  That sharing when we are talking about
>> different privilege domains and persistent storage is a challenge.
>> Hopefully shiftfs can solve that challenge.
>
> Yes, I'm aware of that -- though claiming it's purely a Docker problem
> isn't really fair (it's a problem of any container runtime that wants
> to effectively use overlay filesystems). If shiftfs is going to solve
> the sharing problem for xattrs as well, then I don't have any
> complaints other than "it sucks that we have to add more magical
> translation to a still-not-merged shiftfs".

I have only had discussions with the Docker developers on this.

If you choose not to share a filesystem image between containers or
find it ok to have uids and gids that are in a range that they can be
shared between containers (something that makes a container look
different than a bare metal machine) there are solutions without
shiftfs.

That is if you can allow some arbitrary user to own all of the shared
files in an image.  You can mount the image read-only, and share it
with multiple running containers with different uid and gid mappings.

> But if you say there's not a nicer way to handle this problem, then
> that's good enough for me. :D

It really depends on your design assumptions.  My point is if your
assumption is that if the filesystem can't look ``containerized'' in the
ownership of files you run into trouble.

Last time we had the discussion the Docker folks prioritized sharing
files between different containers with different administrative domains
over running containers more in a more separated fashion.

If you choose to use more storage when running multiple containers that
limitation is not an issue.

Eric
