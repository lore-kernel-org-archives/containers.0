From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCHv3] locks: Filter /proc/locks output on proc pid ns
Date: Wed, 03 Aug 2016 16:09:42 -0500
Message-ID: <87twf1ftk9.fsf@x220.int.ebiederm.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470236078-2389-1-git-send-email-kernel@kyup.com>
	<87k2fxom8a.fsf@x220.int.ebiederm.org>
	<1470243015.13804.7.camel@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1470243015.13804.7.camel-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org> (Jeff Layton's message
	of "Wed, 03 Aug 2016 12:50:15 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Cc: bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org
List-Id: containers.vger.kernel.org

Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org> writes:

> On Wed, 2016-08-03 at 11:23 -0500, Eric W. Biederman wrote:
>> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
>> 
>> > 
>> > On busy container servers reading /proc/locks shows all the locks
>> > created by all clients. This can cause large latency spikes. In my
>> > case I observed lsof taking up to 5-10 seconds while processing
>> > around
>> > 50k locks. Fix this by limiting the locks shown only to those
>> > created
>> > in the same pidns as the one the proc fs was mounted in. When
>> > reading
>> > /proc/locks from the init_pid_ns proc instance then perform no
>> > filtering
>> 
>> If we are going to do this, this should be a recrusive belonging test
>> (because pid namespaces are recursive).
>> 
>> Right now the test looks like it will filter out child pid
>> namespaces.
>> 
>> Special casing the init_pid_ns should be an optimization not
>> something
>> that is necessary for correctness. (as it appears here).
>> 
>> Eric
>> 
>> 
>
> Ok, thanks. I'm still not that namespace savvy -- so there's a
> hierarchy of pid_namespaces?

There is.

> If so, then yeah does sound better. Is there an interface that allows
> you to tell whether a pid is a descendant of a particular
> pid_namespace?

Yes.  And each pid has an array of the pid namespaces it is in so it is
a O(1) operation to see if that struct pid is in a pid namespace.

Dumb question does anyone know the difference between fl_nspid and
fl_pid off the top of your heads?  I am looking at the code and I am
confused why we have to both.  I am afraid that there was some
sloppiness when the pid namespace was implemented and this was the
result.  I remember that file locks were a rough spot during the
conversion but I don't recall the details off the top of my head.

Eric
