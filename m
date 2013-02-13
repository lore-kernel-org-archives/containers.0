From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 18/85] coda: Restrict coda messages to the initial
	user namespace
Date: Wed, 13 Feb 2013 10:44:01 -0800
Message-ID: <87ip5wvytq.fsf@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-18-git-send-email-ebiederm@xmission.com>
	<20130213181450.GJ30800@cs.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130213181450.GJ30800-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org> (Jan Harkes's message of
	"Wed, 13 Feb 2013 13:14:51 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Jan Harkes <jaharkes-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org> writes:

> On Wed, Feb 13, 2013 at 09:51:07AM -0800, Eric W. Biederman wrote:
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> Remove the slight chance that uids and gids in coda messages will be
>> interpreted in the wrong user namespace.
>
> Awesome, I was wondering how to handle uid's from different namespaces
> cleanly in Coda's userspace daemon without resorting to exporting kuids
> to userspace.
>
> But this is a much more elegant solution, every namespace that cares
> about Coda should just run their own mountpoint and userspace daemon.

Do you know if people care enough about coda that they will want to
export run coda multiple mountpoint and userspace daemons?

I have never seen anyone running coda so I was suspecting that coda was
a filesystem that was gradually fading away.

Eric
