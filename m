From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/15] Signal semantics
Date: Mon, 30 Jul 2007 13:31:44 +0400
Message-ID: <46ADB000.1000705@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B5C7.9040407@openvz.org>
	<20070727123153.GA92@tv-sign.ru> <46A9F54B.5050000@openvz.org>
	<20070727184604.GB1072@us.ibm.com>
	<20070727195943.GA25878@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070727195943.GA25878-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

[snip]

>> | Maybe it's worth disabling cross-namespaces ptracing...
>>
>> I think so too. Its probably not a serious limitation ?
> 
> Several people think we will implement 'namespace entering' through a
> ptrace hack, where maybe the admin ptraces the init in a child pidns,

Why not implement namespace entering w/o any hacks? :)

> makes it fork, and makes the child execute what it wants (i.e. ps -ef).
> 
> You're talking about killing that functionality?

No. We're talking about disabling the things that are not supposed 
to work at all.

> -serge
> 
