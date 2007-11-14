From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netns compilation
Date: Wed, 14 Nov 2007 09:06:02 -0700
Message-ID: <m1bq9w24np.fsf@ebiederm.dsl.xmission.com>
References: <473B0DF7.2050509@fr.ibm.com> <473B0FC7.6040900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473B0FC7.6040900-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Wed,
	14 Nov 2007 18:09:59 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> Daniel Lezcano wrote:
>> Actually the CONFIG_NET_NS is depending on CONFIG_NET and !CONFIG_SYSFS
>> 
>> In order to disable CONFIG_SYSFS, I must specify CONFIG_EMBEDDED to have 
>> the choice to unset the sysfs.
>> 
>> Why don't we make CONFIG_NET_NS depends on CONFIG_NET and 
>> CONFIG_SYSFS_DEPRECATED ?
>> 
>
> AFAIK the SYSFS_DEPRECATED hides the sysfs functionality (files)
> that is not recommended to use, but doesn't disable the sysfs
> filesystem as is. On the other hand the NET_NS doesn't require 
> any deprecated sysfs files, it just can't work at all with the 
> SYSFS turned on. 
>
> That's why the things look like this.

Exactly.  Once we get the sysfs support merged this restriction will go away
but until then attempting to register a two copies of the loopback device
with sysfs is fatal.

Eric
