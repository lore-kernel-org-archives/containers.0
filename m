From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 18:51:55 -0500
Message-ID: <8BC8AF03-457C-4B26-9500-955F91A8A60E@oracle.com>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <1231274682.20316.65.camel@heimdal.trondhjem.org> <20090106215831.GE18147@us.ibm.com> <m1eizg11fy.fsf@frodo.ebiederm.org> <1231283734.8041.6.camel@heimdal.trondhjem.org> <20090106233238.GD13785@fieldses.org> <1231284943.8041.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1231284943.8041.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Jan 6, 2009, at Jan 6, 2009, 6:35 PM, Trond Myklebust wrote:
> On Tue, 2009-01-06 at 18:32 -0500, J. Bruce Fields wrote:
>> On Tue, Jan 06, 2009 at 06:15:34PM -0500, Trond Myklebust wrote:
>>> On Tue, 2009-01-06 at 15:04 -0800, Eric W. Biederman wrote:
>>>> That implies to me you want to capture the value at mount time,  
>>>> and to
>>>> pass it in to the rpc_call creation, and only at very specific well
>>>> defined points where we interact with user space should we examine
>>>> current->utsname().  At which point there should be no question
>>>> of current->utsname() is valid as the user space process is alive.
>>>
>>> Why pretend that the filesystem is owned by a particular  
>>> namespace? It
>>> can, and will be shared among many containers...
>>
>> If the only purpose of this is to fill in the auth_unix cred then
>> shouldn't it be part of whatever cred structures are passed around?
>
> So how does tracking it in a shared structure like the rpc_client  
> help?
> If you consider it to be part of the cred, then it needs to be tracked
> in the cred...

I think generating a proper AUTH_SYS cred, given the existence of  
containers, is the essential question here.

However, we use nodename for lock owners too... perhaps that deserves  
a separate solution.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
