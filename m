From: Daniel Lezcano <dlezcano-juSfH4iHXoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][patch 0/3] Network container subsystem - bind filtering
Date: Wed, 05 Sep 2007 17:41:03 +0200
Message-ID: <46DECE0F.6060606@meiosys.com>
References: <20070904170022.964253374@dyn-9-101-17-26.toulouse-stg.fr.ibm.com>
	<20070905153741.GK1403@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070905153741.GK1403-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>> Paul Menage mentionned, a few weeks ago, he wanted a bind filtering 
>> for containers. Here it is  :) 
>>
>> The following patches are a proposition to bring IP isolation to a container.
>>
>> After looking more closely at the code I found that security hooks are
>> at the right place to catch socket calls. The IP isolation relies on the
>> security hooks and that has the advantage of not having the kernel code modified,
>> (expect container.h and makefile/kconfig), the patchset provide just a new 
>> file container_network.c
>>
>> Roughly, a container has a subsystem for the network (only ipv4). 
> 
> Just curious - why ipv4 only?  When i wrote the bsdjail lsm, using the
> same approach, doing ipv6 address was pretty simple.  Did something
> change?  Or is ipv4 just a temporary restriction while you prototype?

It is a temporary restriction for the prototype.
> 
>> This subsystem contains the list of the addresses allowed to be used by the 
>> container. If a container tries to bind to an address not contained into
>> this list, the bind will fail with EPERM. Of course the bind is allowed to
>> INADDR_ANY.
>>
>> If this approach is ok for everyone, I can extend the bind filtering to
>> consolidate the IP isolation.
> 
> You'll want to cc: the linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org list on
> this patchset.

Sure.

> thanks,
> -serge
> 
