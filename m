From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Sun, 25 Jun 2017 23:51:40 +1000
Message-ID: <5bef361a-bc31-f3bc-f513-e728a48f0524@suse.de>
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
	<87zicwb3hu.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87zicwb3hu.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>>>>>> So my essential point is that building the real kuid into the permanent
>>>>>> record of the xattr damages image portability, which is touted as one
>>>>>> of the real advantages of container images.
>>>>>
>>>>> 'container images' aren't portable in that sense now - for at least
>>>>> many cases - because you have to shift the uid.  However you're doing
>>>>> that, you may be able to shift the xattr the same way.
>>>>
>>>> Piling more things on top of that issue isn't going to make the issue easier to
>>>> solve IMO. Would shiftfs or shift-bindmounts also have to do translation of
>>>> arbitrary xattrs? Plus I would think that handling xattrs would be harder than
>>>> {u,g}ids because the image unpacker now has to be aware of all xattrs that
>>>> require remapping (Which might be an ever-growing list).
>>>>
>>>> The user namespace incompatibility with the VFS's hard-coding of k{u,g}id values
>>>> in inodes is an issue that we really shouldn't be encouraging IMO [especially
>>>> given how hard it's been so far to solve that problem.]
>>>
>>> There is one very simple solution to the problem.
>>>
>>> Perform the unpacking in your user namespace.
>>
>> I'm not aware of any major container runtime that couples image
>> unpacking to the runtime components. Docker hasn't done it for years
>> (it's split between runc and Docker/containerd). rkt hasn't ever done
>> it (runtime stages are totally separate to image unpacking). cri-o
>> doesn't do it either. I believe that only singularity does something
>> like that (though singularity is also not actually a "container
>> runtime" in the modern meaning of the term).
>>
>> Not to mention that the OCI standards explicitly separate the two
>> concepts, and there exist tools to manipulate images that don't
>> explicitly use containers (or namespaces for that matter) either[1].
> 
> It doesn't require coupling it just requires knowing which uids and
> gids (from the filesystem perspective) your images are going to use
> when you unpack them.

Yeah, I assumed that would also work. I was just responding to "perform 
the unpacking in your user namespace" and was just clarifying that 
currently no container runtime would want to do that.

> And all of that can work as an unprivileged user if done carefully.
> Which should reduce the possibility of danger.

:+1: I'm definitely going to be using this within umoci's rootless 
containers support as well as anywhere else it's appropriate.

Cheers.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
