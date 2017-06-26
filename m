From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Mon, 26 Jun 2017 16:14:51 +1000
Message-ID: <e6df64d8-c9ba-5726-98e7-36634c0edb8a@suse.de>
References: <20170623160026.GA18257@mail.hallyn.com>
	<aa62373e-7cd6-39dd-2e38-2b6d6dbe18a8@schaufler-ca.com>
	<20170623163030.GA18820@mail.hallyn.com>
	<1498237641.3641.15.camel@HansenPartnership.com>
	<20170623172016.GA19551@mail.hallyn.com>
	<553a72c4-eda9-52d6-2ae2-f8687c0c7c70@suse.de>
	<87lgogdz2t.fsf@xmission.com>
	<f1716e8c-dba8-a051-6bc7-285f13ffcaf0@suse.de>
	<87zicwb3hu.fsf@xmission.com>
	<5bef361a-bc31-f3bc-f513-e728a48f0524@suse.de>
	<20170625164558.GA24471@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170625164558.GA24471-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

>>>>> There is one very simple solution to the problem.
>>>>>
>>>>> Perform the unpacking in your user namespace.
>>>>
>>>> I'm not aware of any major container runtime that couples image
>>>> unpacking to the runtime components >> Yeah, I assumed that would also work. I was just responding to
>> "perform the unpacking in your user namespace" and was just
>> clarifying that currently no container runtime would want to do
>> that.
> 
> That's exactly what lxc does.

Oh really, I wasn't aware of that. Thanks -- I haven't really looked at 
LXC's templates before, I should take a look at that over the weekend.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
