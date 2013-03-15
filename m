From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 0/4] fix depvpts in user namespaces
Date: Fri, 15 Mar 2013 20:01:42 +0400
Message-ID: <514345E6.2070901@parallels.com>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<87boalt0vi.fsf@xmission.com> <20130315140040.GB3782@sergelap>
	<5143333E.1040100@parallels.com> <20130315152133.GB24305@sergelap>
	<51433DBE.9020109@parallels.com> <20130315155822.GA30652@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130315155822.GA30652@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/15/2013 07:58 PM, Serge Hallyn wrote:
> Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>> On 03/15/2013 07:21 PM, Serge Hallyn wrote:
>>> Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>>>> On 03/15/2013 06:00 PM, Serge Hallyn wrote:
>>>>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>>>>> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
>>>>>>
>>>>>>> Hi,
>>>>>>>
>>>>>>> devpts mounts in user namespaces is queued for 3.9. However, while playing
>>>>>>> with it I found it to be less than ideal. Although it could possibly work
>>>>>>> with custom software that can be made to point to /dev/pts/ptmx, a few things
>>>>>>> prevent it from working correctly for people that, like us, are booting full
>>>>>>> distributions.
>>>>>>
>>>>>> Full distributions that have not been modified to be minimally container
>>>>>> aware.
>>>>>
>>>>> Right, in fact in this case it doesn't need to be minimally container
>>>>> aware, you just create the bind mount yourself and init just needs to
>>>>> accept that it shouldn't touch it.
>>>>>
>>>>
>>>> Well, what if it doesn't?
>>>>
>>>> At least in the system I am using, centos6, udev mounts a tmpfs in a
>>>> temporary location, and then mount --move this to /dev. This is now
>>>> empty, and devpts will be mounted ontop of that.
>>>
>>> This also messes up your /dev/ttyN setup right?  How are you handling
>>> that?
>>>
>> very simple: udev will just mknod everything back, so let him!
> 
> So you're not using bind-mounted ptys over /dev/ttyN?
> 
Not in particular, and I haven't felt the need yet.
