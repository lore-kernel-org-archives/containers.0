From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [libvirt] kernel summit topic - 'containers end-game'
Date: Thu, 02 Jul 2009 18:58:00 +0200
Message-ID: <4A4CE718.6030300@free.fr>
References: <20090623145611.GB19332@us.ibm.com>	<661de9470906290335i74f76a55t57438a781e6a84c8@mail.gmail.com>
	<20090630200613.GA22283@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090630200613.GA22283-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Daniel Veillard <veillard-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Balbir Singh (balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>   
>> On Tue, Jun 23, 2009 at 8:26 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>>     
>>> A topic on ksummit agenda is 'containers end-game and how do we
>>> get there'.
>>>
>>> So for starters, looking just at application (and system) containers, what do
>>> the libvirt and liblxc projects want to see in kernel support that is currently
>>> missing?  Are there specific things that should be done soon to make containers
>>> more useful and usable?
>>>
>>> More generally, the topic raises the question... what 'end-games' are there?
>>> A few I can think of off-hand include:
>>>
>>>        1. resource control
>>>       
>> We intend to hold a io-controller minisummit before KS, we should have
>> updates on that front. We also need to discuss CPU hard limits and
>> Memory soft limits. We need control for memory large page, mlock, OOM
>> notification support, shared page accounting, etc. Eventually on the
>> libvirt front, we want to isolate cgroup and lxc support into
>> individual components (long term)
>>     
>
> Thanks, Balbir.  By the last sentence, are you talking about having
> cgroup in its own libcgroup, or do you mean something else?
>
> On the topic of cgroups, does anyone not agree that we should try
> to get rid of the ns cgroup, at least once user namespaces can
> prevent root in a container from escaping their cgroup?
>   
I agree if there is a compatibility flag to clone the parent when 
creating a new cgroup, as suggested Paul.

Thanks
  -- Daniel
