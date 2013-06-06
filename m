From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Requirements for CAP_SYS_ADMIN on setns() ?
Date: Thu, 06 Jun 2013 11:15:11 -0700
Message-ID: <87bo7j6r80.fsf@xmission.com>
References: <20130606100149.GG30217@redhat.com> <20130606134802.GA2930@ac100>
	<87txlb8atb.fsf@xmission.com>
	<20130606164428.GA4687@austin.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130606164428.GA4687-anj0Drq5vpzx6HRWoRZK3AC/G2K4zDHf@public.gmane.org> (Serge E. Hallyn's
	message of "Thu, 6 Jun 2013 11:44:28 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>> >> Is it not sufficient to rely on the permissions on the /proc/$PID/ns/XXX
>> >> file to control access to a namespace, and thus allow setns() without
>> >> a CAP_SYS_ADMIN check ?

The permissions on /proc/$PID/ns/XXX are sufficient to control access
but they are not ok to allow use.

>> >> ie setns() is basically useless unless you
>> >> already have sufficient privileges to get a file descriptor for the
>> >> namespace, so why does setns need an additional privilege check beyond
>> >> that done at time of open() on the proc file.

To be very clear.

setns requires CAP_SYS_ADMIN because changing the namespaces for your
children can result in tricking a suid root application and thus lead
to privilege escalation.

If you run setns inside a user namespace that you control the privilege
escalation is not possible and so setns is allowed.

Eric
