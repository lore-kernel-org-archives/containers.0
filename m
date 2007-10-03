From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: netns : close all sockets at unshare ?
Date: Wed, 03 Oct 2007 10:40:49 +0200
Message-ID: <47035591.4030300@fr.ibm.com>
References: <4702BBF4.60903@fr.ibm.com>
	<m14ph9i1l3.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m14ph9i1l3.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
> 
>> Hi,
>>
>> I was looking at some cornercases and trying to figure out what happens if
>> someone does:
>>
>> 1 - fd = socket(...)
>> 2 - unshare(CLONE_NEWNET)
>> 3 - bind(fd, ...) / listen(fd, ...)
>>
>> There is here an interaction between two namespaces.
>> Trying to catch all these little tricky paths everywhere with the network
>> namespace is painful, perhaps we should consider a more radical solution.
> 
> Huh?
> 
> socket() puts the namespace on struct sock.
> bind/listen etc just look at that namespace. 
> 
> Unless I'm blind it is simple and it works now.

Yes, it will work.

Do we want to be inside a network namespace and to use a socket 
belonging to another network namespace ? If yes, then my remark is 
irrelevant.

>> Shall we close all fd sockets when doing an unshare ? like a close-on-exec
>> behavior ?
> 
> I think adopting that policy would dramatically reduce the usefulness
> of network namespaces.
> 
> Making the mix and match cases gives the implementation much more flexibility
> and it doesn't appear that hard right now.

I am curious, why such functionality is useful ?
