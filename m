From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 17:43:10 -0800
Message-ID: <m1ocjf1k9d.fsf__23271.8205465519$1266975940$gmane$org@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266966581.3973.675.camel@bigi> (jamal's message of "Tue\,
	23 Feb 2010 18\:09\:41 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> writes:

> On Tue, 2010-02-23 at 12:00 -0800, Eric W. Biederman wrote:
>
>> That point of the mount to hold a persistent reference to the
>> namespace without using a process.
>> 
>> The point of the of the to be written set_ns call is to change
>> the default network namespace of the process such that all future
>> open/bind/socket calls happen in the referenced network namespace.
>
> Ok, i like it ;-> Patches RSN? Let me if you want someone to test..

My target will be 2.6.35.   There is an old prototype implementation
that hit the containers list and I think netdev a year or so ago.

>> The are a few stray places like sysfs where it is the mount point
>> not current->nsproxy->net_ns that will determine what we see.
>
> Is sysfs considered "usable enough" for namespaces?

Mine is ;) I had a bad cold and didn't get through all of the patches
this development cycle, just all the prereqs.  I plan on getting that
final conversation started for as soon as 2.6.34-rc1 hits.

>> Attributes of the specific namespace?
>
> Well, example what is being un/shared etc. 

Got it.  Implementation wise I'm going to stash a pointer
to the namespace in a inode or super block, simple.

Eric
