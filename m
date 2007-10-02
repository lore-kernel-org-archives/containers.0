From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch -mm 0/5] mqueue namespace
Date: Tue, 02 Oct 2007 13:06:29 +0200
Message-ID: <47022635.2050706@fr.ibm.com>
References: <20071002084608.149781400@fr.ibm.com>
	<m1przxlrim.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1przxlrim.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
> 
>> Hello,
>>
>> Here's the mqueue namespace patchset. 
>>
>> If you're OK with it, I'll rebase on the next -mm which should contain
>> the new CONFIG_NAMESPACES and send to andrew.
> 
> Well the CLONE flag is a conflict with the network namespace.

Indeed. For the moment, this is for review because I'm waiting for a few 
namespace patches to go in -mm. When this time comes, I'll rebase.  

> I was hoping someone had managed to make message queues work
> through the filesystem API and then this would just be a matter
> of multiple mounts of a filesystem.

I've added a small helper routine to handle the case of a single
super_block per namespace. I called it get_sb_single_per_data()

It could be used in pid namespace also and probably a few other fs.

> However given the syscalls and the rest I guess this really does
> count as a separate namespace :(

yep ...

C.
