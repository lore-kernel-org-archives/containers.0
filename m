From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [PATCH 0/2] namespaces: log namespaces per task
Date: Sat, 03 May 2014 14:58:48 -0700
Message-ID: <1399154328.2505.29.camel@dabdike.int.hansenpartnership.com>
References: <cover.1398176489.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1398176489.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2014-04-22 at 14:12 -0400, Richard Guy Briggs wrote:
> Questions:
> Is there a way to link serial numbers of namespaces involved in migration of a
> container to another kernel?  (I had a brief look at CRIU.)  Is there a unique
> identifier for each running instance of a kernel?  Or at least some identifier
> within the container migration realm?

Are you asking for a way of distinguishing an migrated container from an
unmigrated one?  The answer is pretty much "no" because the job of
migration is to restore to the same state as much as possible.

Reading between the lines, I think your goal is to correlate audit
information across a container migration, right?  Ideally the management
system should be able to cough up an audit trail for a container
wherever it's running and however many times it's been migrated?

In that case, I think your idea of a numeric serial number in a dense
range is wrong.  Because the range is dense you're obviously never going
to be able to use the same serial number across a migration.  However,
if you look at all the management systems for containers, they all have
a concept of some unique ID per container, be it name, UUID or even
GUID.  I suspect it's that you should be using to tag the audit trail
with.

James
