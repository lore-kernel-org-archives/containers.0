From: "Ian jonhson" <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: container userspace tools
Date: Sat, 25 Oct 2008 19:06:17 +0800
Message-ID: <8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
References: <48EF35F1.2060308@fr.ibm.com>
	<8f34198c0810150033p42b74badrf194e66433e32cd5@mail.gmail.com>
	<48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48F5EBF3.1070204-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Dear Daniel,

I have tested the container tools in my VM.
It runs very well. But I can not see any highlight
show via container. I believe that two group of
user's processes (with same uid) can be isolated
via container when both of them access files or
are enforced with different quota. But I don't know
how to get the functionalities run.

Any help?

Thanks in advance.

On Wed, Oct 15, 2008 at 9:11 PM, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> Ian jonhson wrote:
>>>
>>> The problem is related to the kernel version you have and a missing
>>> functionality.
>>>
>>> You should use the kernel coming from:
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git
>>>
>>
>> It needs not to set "Container support"  if I run with above kernel,
>> right?
>> I have downloaded the source codes.
>
> The container support will enable at the compile time the different features
> in the kernel. I added this kernel option because I was tired to activate
> the different features one by one as described in the README file. If you
> don't specify this option, the container code will be there in the kernel
> but the not active. So you have to set it.
>

OK, I have activated the "container support" step by step according to
README, but I met a mismatch setting:
