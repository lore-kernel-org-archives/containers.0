From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/1][NETNS49] Make af_unix autobind per namespace
Date: Wed, 03 Oct 2007 15:11:44 +0200
Message-ID: <47039510.7040001@fr.ibm.com>
References: <20071002151846.827206013@mai.toulouse-stg.fr.ibm.com>	<m1fy0tjv04.fsf@ebiederm.dsl.xmission.com>	<4702AF67.1010707@fr.ibm.com>
	<47034F4F.5000901@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47034F4F.5000901-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Daniel Lezcano wrote:
>> Eric W. Biederman wrote:
>>> Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>>
>>>> The following patch change autobind fonction to use the ordernum
>>>> from the network namespace instead of using the local static variable.
>>> Why do we care?
>>> Information leak?
>>> Some application is expecting a predictable autobind value?
>>>
>>> Just skimming the code it looks like it will work correctly without
>>> this.
>> I think my summary is ... too short :)
>>
>> I don't see any applications taking care of this. If they ask for an
>> abstract socket, then they don't care about the bind result. So
>> probably, the patchset is totally useless.
>>
>> But from the POV of the checkpoint/restart, we should check if this
>> value is somewhere visible from userspace and so storable by an
>> application.
> 
> we do not care with this in checkpointing. One namespace socket does not
> see other namespace socket

my 2 cnts,

when 'restarting' a socket bound to an abstract name, we will have 
a EADDRINUSE if we try to rebind it to an abtract name which is 
already in use by a socket in a another namespace ? 

it seems to me that this is an identifier and like any identifier
it should be private to the namespace, which probably means having
unix_abstract_socket_table[] per net namespace.

Cheers,

C. 
