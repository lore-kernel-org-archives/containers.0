From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Tue, 4 Sep 2012 13:16:55 +0400
Message-ID: <5045C707.9020001@parallels.com>
References: <20120830211832.GA3297@redhat.com> <878vcwjabu.fsf@xmission.com>
	<20120830225002.GA9226@redhat.com>
	<87bohrhqai.fsf@xmission.com> <5044629C.3030909@parallels.com>
	<87r4qi6g6k.fsf@xmission.com> <5045BF05.9050707@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5045BF05.9050707-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 09/04/2012 12:42 PM, Glauber Costa wrote:
> boot_id as a pid namespace id is a very well defined concept. We just
> need an interface to set it up to make it stable across migration. Maybe
> we can accept writes to this file as valid, provided the pid namespace
> has only the init process.
> 
> Then any tool could clone, mount proc, set this id, and continue
> normally. Any objections ?

Ok, the above is totally jet-lag induced garbage. I totally forgot this
is a sysctl interface.

We do per-netns sysctls just fine, why can't we do them here as well ?
