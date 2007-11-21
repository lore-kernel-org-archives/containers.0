From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/3] The sysctl shadows
Date: Wed, 21 Nov 2007 12:20:38 +0300
Message-ID: <4743F866.9070100@openvz.org>
References: <4742C73C.3010904@openvz.org> <4742C86E.6060705@openvz.org>
	<1195579009.29578.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1195579009.29578.7.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Tue, 2007-11-20 at 14:43 +0300, Pavel Emelyanov wrote:
>> +static void ctl_free_table(struct ctl_table *t)
>> +{
>> +       struct ctl_table *tmp;
>> +
>> +       for (tmp = t; tmp->ctl_name || tmp->procname; tmp++)
>> +               if (tmp->child)
>> +                       ctl_free_table(tmp->child);
>> +
>> +       kfree(t);
>> +} 
> 
> Are you worried about the recursion at all?

I do, but

1. sysctl tables are _never_ deeper than 5 levels (as they 
   _always_ come from the kernel space)
2. registering sysctl tables happens from __init calls usually
   so the stack is not filled at all
3. after implementing the sysctl paths this will vanish ;)

Moreover, this is not the only case of recursion in the kernel :)

Thanks,
Pavel

> -- Dave
> 
> 
