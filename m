From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/5] Move the user namespace under the option
Date: Mon, 01 Oct 2007 11:54:45 +0400
Message-ID: <4700A7C5.5080005@openvz.org>
References: <46FA7D4D.8040808@openvz.org> <46FA8087.6060307@openvz.org>
	<46FBA2A4.2040909@fr.ibm.com>
	<Pine.LNX.4.64.0709270837220.5275@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709270837220.5275-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Robert P. J. Day" <rpjday-mn4gwa5WIIQysxA8WJXlww@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Robert P. J. Day wrote:
> On Thu, 27 Sep 2007, Cedric Le Goater wrote:
> 
>>> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
>>> index b5f41d4..dda160c 100644
>>> --- a/include/linux/user_namespace.h
>>> +++ b/include/linux/user_namespace.h
>>> @@ -17,7 +17,7 @@ struct user_namespace {
>>>
>>>  extern struct user_namespace init_user_ns;
>>>
>>> -#ifdef CONFIG_USER_NS
>>> +#ifdef CONFIG_NAMESPACES_EXPERIMENTAL
> 
> is it really a good precedent to introduce Kconfig variables that
> literally include the word "EXPERIMENTAL"?

How else can we call it? I proposed one config option for
each namespace with "depends on EXPERIMENTAL" dependency,
but everyone else said that two options are much better.

> rday
