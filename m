From: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow directory
	support.
Date: Mon, 30 Jul 2007 16:09:06 +0900
Message-ID: <46AD8E92.7080002@suse.de>
References: <1182446577.8138.29.camel@localhost>	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>	<20070621211637.GB10583@suse.de>	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>	<20070622001328.GA14113@suse.de>	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>	<20070625212339.GA13398@kroah.com>	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>	<46A3B449.3090409@gmail.com>
	<20070722202508.GA18018@suse.de>
	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
	<46A425F9.1030008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46A425F9.1030008-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Eric.

Tejun Heo wrote:
> Eric W. Biederman wrote:
>> Further while there are a few little nits I think mostly Tejun is 
>> mostly objecting to the fundamental complexity of the problem rather
>> then to things that can be fixed by a cleaner implementation.
> 
> Oh well, I don't think so but I might be wrong.

And I'm wrong.  Mine didn't turn out to be much cleaner than yours.
What I did was (still broken)...

* No shadower/shadowee.  Each dentry is tagged.
* dentries of tagged sd's are taken out of dcache and always go through
->lookup() where the correct sd is looked up considering the current tag.

Tagging and adding new entries could be done rather cleanly but shooting
down existing dentries on rename/move turned out to be a mess.  Things
will be much simpler if no sysfs dentry is hashed on dcache and always
go through ->lookup() but that will hurt big machines.

The basic problem here is that dcache layer doesn't allow different
views and sysfs shadow is trying to work behind its back.  I don't think
this is a viable approach.  Both implementations bend too many rules and
 are too fragile.  It will be a genuine pain in the ass to maintain.

Sorry that I can't come up with an alternative but NACK.

-- 
tejun
