From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: netns : close all sockets at unshare ?
Date: Thu, 04 Oct 2007 17:27:03 +0200
Message-ID: <47050647.2030703@fr.ibm.com>
References: <4702BBF4.60903@fr.ibm.com>	<m14ph9i1l3.fsf@ebiederm.dsl.xmission.com>	<47035591.4030300@fr.ibm.com>
	<m1r6kccexw.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1r6kccexw.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
>> Yes, it will work.
>>
>> Do we want to be inside a network namespace and to use a socket belonging to
>> another network namespace ? If yes, then my remark is irrelevant.
> 
> Yes we do.
> 
>>>> Shall we close all fd sockets when doing an unshare ? like a close-on-exec
>>>> behavior ?
>>> I think adopting that policy would dramatically reduce the usefulness
>>> of network namespaces.
>>>
>>> Making the mix and match cases gives the implementation much more flexibility
>>> and it doesn't appear that hard right now.
>> I am curious, why such functionality is useful ?
> 
> There are several reasons.  Partly it is the principle of building
> general purpose tools that can be used in a flexible way.
> 
> The biggest practical use I can see is that a control program outside
> of a network namespace can configure and setup someone else's network
> stack, perhaps preventing the need to enter someone else's container.
> 
> Another use is having a socket in an original network namespace for
> doing a stdin/stdout style connections.

this is also required in the HPC world. batch managers and MPI frameworks 
often redirect stdios on the socket which was used to remotely execute
the job. Now, if we introduce a container around the job to be able
to migrate it, we are in the same scenario.  

that socket is in the original network namespace and the fds are from
processes living in a container. 

C.
 
> The planetlab folks are actually actively using this functionality
> already, and there was a thread several months ago about how this
> functionality was important and how they were using it.
> 
> This also preserves normal unix file descriptor passing semantics.
> 
> A final reason for it is that it removes the need for a lot of
> brittle special cases when network namespaces are mixed in something
> other then a 1-1 correspondence with other namespaces.  Like the one
> you were concerned with in unshare.  Handling this case means
> everything just works.
> 
> So it may be a touch harder to implement but because we don't add
> special rules it is much easier to review.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
